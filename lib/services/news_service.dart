import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';

class NewsService {
  Future<List<NewsModel>> fetchEconomicNews() async {
    try {
      // Endpoint público estável para simular a latência e o consumo de rede real
      final response = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=5'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        // Quando você tiver uma chave da HG Brasil ou NewsAPI, basta trocar a URL acima 
        // e adaptar o parseamento do JSON aqui dentro.
        
        // Mapeamento temático focado em finanças, gestão inteligente e eficiência:
        final List<String> dicasMercado = [
          "Selic estável: Onde alocar seu fundo de reserva com segurança este mês?",
          "Corte de Despesas Fixas: Como auditorias de contratos reduzem custos em até 25%.",
          "Planejamento Orçamentário: Ferramentas modernas para mitigar a inadimplência.",
          "Eficiência Energética: O impacto real da transição para LED e energia limpa no caixa.",
          "Gestão de Fluxo de Caixa: Estratégias preventivas para evitar furos no orçamento.",
        ];

        final List<dynamic> body = jsonDecode(response.body);
        return List.generate(body.length, (index) {
          return NewsModel(
            title: dicasMercado[index % dicasMercado.length],
            description: "Acompanhe análises e indicadores do mercado para otimizar a distribuição de recursos, gerenciar ativos e aplicar boas práticas de sustentabilidade financeira.",
            source: "Finanças & Insights",
          );
        });
      }
    } catch (_) {
      // Fallback automático caso falte internet ou ocorra timeout
    }
    return _getFallbackTips();
  }

  List<NewsModel> _getFallbackTips() {
    return [
      NewsModel(
        title: "Reserva de Emergência e Liquidez",
        description: "Manter ativos alocados em CDI de liquidez diária garante proteção contra imprevistos orçamentários.",
        source: "Dica de Gestão",
      ),
      NewsModel(
        title: "Manutenção Preventiva vs Corretiva",
        description: "Estudos apontam que vistorias planejadas poupam até 40% em relação a reparos emergenciais de infraestrutura.",
        source: "Economia Inteligente",
      ),
    ];
  }
}